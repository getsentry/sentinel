CREATE DATABASE IF NOT EXISTS sentry_analytics;
USE sentry_analytics;

CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    organization_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    
    INDEX idx_organization (organization_id),
    INDEX idx_slug (slug)
);

CREATE TABLE IF NOT EXISTS error_events (
    id BIGSERIAL PRIMARY KEY,
    event_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    level VARCHAR(20) NOT NULL CHECK (level IN ('debug', 'info', 'warning', 'error', 'fatal')),
    message TEXT NOT NULL,
    culprit VARCHAR(1024),
    platform VARCHAR(64),
    environment VARCHAR(64) DEFAULT 'production',
    release VARCHAR(250),
    tags JSONB DEFAULT '{}',
    user_data JSONB DEFAULT '{}',
    context JSONB DEFAULT '{}',
    stack_trace TEXT,
    
    PRIMARY KEY (id, timestamp),
    INDEX idx_project_timestamp (project_id, timestamp DESC),
    INDEX idx_level_timestamp (level, timestamp DESC),
    INDEX idx_event_id (event_id)
) PARTITION BY RANGE (timestamp);

CREATE TABLE error_events_2024_01 PARTITION OF error_events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE IF NOT EXISTS affected_users (
    user_id VARCHAR(255) NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    first_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    event_count INTEGER DEFAULT 1,
    
    PRIMARY KEY (user_id, project_id),
    INDEX idx_last_seen (last_seen DESC)
);

WITH error_summary AS (
    SELECT 
        p.name AS project_name,
        p.slug AS project_slug,
        DATE_TRUNC('hour', e.timestamp) AS hour,
        e.level,
        COUNT(*) AS error_count,
        COUNT(DISTINCT e.user_data->>'id') AS affected_users,
        ARRAY_AGG(DISTINCT e.environment) AS environments
    FROM error_events e
    INNER JOIN projects p ON e.project_id = p.id
    WHERE 
        e.timestamp >= NOW() - INTERVAL '24 hours'
        AND p.is_active = true
    GROUP BY p.name, p.slug, DATE_TRUNC('hour', e.timestamp), e.level
),
hourly_trends AS (
    SELECT 
        project_name,
        hour,
        SUM(CASE WHEN level = 'error' THEN error_count ELSE 0 END) AS errors,
        SUM(CASE WHEN level = 'warning' THEN error_count ELSE 0 END) AS warnings,
        SUM(affected_users) AS total_affected_users,
        LAG(SUM(error_count)) OVER (PARTITION BY project_name ORDER BY hour) AS prev_hour_count
    FROM error_summary
    GROUP BY project_name, hour
)
SELECT 
    project_name,
    hour,
    errors,
    warnings,
    total_affected_users,
    ROUND(
        CASE 
            WHEN prev_hour_count > 0 
            THEN ((errors + warnings - prev_hour_count)::NUMERIC / prev_hour_count) * 100
            ELSE 0 
        END, 2
    ) AS percent_change,
    CASE 
        WHEN errors > 100 THEN 'critical'
        WHEN errors > 50 THEN 'high'
        WHEN errors > 10 THEN 'medium'
        ELSE 'low'
    END AS severity
FROM hourly_trends
WHERE hour >= NOW() - INTERVAL '12 hours'
ORDER BY hour DESC, errors DESC;

SELECT 
    project_id,
    DATE_TRUNC('day', timestamp) AS day,
    level,
    COUNT(*) AS daily_count,
    SUM(COUNT(*)) OVER (
        PARTITION BY project_id, level 
        ORDER BY DATE_TRUNC('day', timestamp)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    AVG(COUNT(*)) OVER (
        PARTITION BY project_id, level 
        ORDER BY DATE_TRUNC('day', timestamp)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7d,
    RANK() OVER (
        PARTITION BY DATE_TRUNC('day', timestamp) 
        ORDER BY COUNT(*) DESC
    ) AS daily_rank,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (
            PARTITION BY DATE_TRUNC('day', timestamp)
        ), 2
    ) AS percent_of_daily_total
FROM error_events
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY project_id, DATE_TRUNC('day', timestamp), level;

DELIMITER //

CREATE PROCEDURE aggregate_error_metrics(
    IN p_project_id UUID,
    IN p_start_date TIMESTAMP,
    IN p_end_date TIMESTAMP
)
BEGIN
    DECLARE v_total_errors INT DEFAULT 0;
    DECLARE v_unique_users INT DEFAULT 0;
    DECLARE v_error_rate DECIMAL(5,2);
    
    START TRANSACTION;
    
    SELECT 
        COUNT(*),
        COUNT(DISTINCT user_data->>'id')
    INTO v_total_errors, v_unique_users
    FROM error_events
    WHERE 
        project_id = p_project_id
        AND timestamp BETWEEN p_start_date AND p_end_date
        AND level IN ('error', 'fatal');
    
    SET v_error_rate = v_total_errors / TIMESTAMPDIFF(HOUR, p_start_date, p_end_date);
    
    INSERT INTO project_metrics (
        project_id,
        date_range_start,
        date_range_end,
        total_errors,
        unique_users_affected,
        error_rate_per_hour,
        calculated_at
    ) VALUES (
        p_project_id,
        p_start_date,
        p_end_date,
        v_total_errors,
        v_unique_users,
        v_error_rate,
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        total_errors = VALUES(total_errors),
        unique_users_affected = VALUES(unique_users_affected),
        error_rate_per_hour = VALUES(error_rate_per_hour),
        calculated_at = NOW();
    
    COMMIT;
    
    SELECT 
        v_total_errors AS total_errors,
        v_unique_users AS unique_users,
        v_error_rate AS error_rate;
END//

DELIMITER ;

CREATE INDEX idx_error_events_composite 
ON error_events(project_id, level, timestamp DESC)
WHERE level IN ('error', 'fatal');

CREATE INDEX idx_error_events_gin_tags 
ON error_events USING GIN (tags);

CREATE MATERIALIZED VIEW project_error_summary AS
SELECT 
    p.id AS project_id,
    p.name AS project_name,
    DATE_TRUNC('hour', e.timestamp) AS hour,
    COUNT(*) FILTER (WHERE e.level = 'error') AS error_count,
    COUNT(*) FILTER (WHERE e.level = 'warning') AS warning_count,
    COUNT(DISTINCT e.user_data->>'id') AS affected_users,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY LENGTH(e.message)) AS p95_message_length,
    ARRAY_AGG(DISTINCT e.culprit) FILTER (WHERE e.culprit IS NOT NULL) AS top_culprits
FROM projects p
LEFT JOIN error_events e ON p.id = e.project_id
WHERE e.timestamp >= NOW() - INTERVAL '7 days'
GROUP BY p.id, p.name, DATE_TRUNC('hour', e.timestamp);

REFRESH MATERIALIZED VIEW CONCURRENTLY project_error_summary;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT 
    p.name,
    COUNT(*) AS total_errors,
    COUNT(DISTINCT e.user_data->>'id') AS users_affected
FROM error_events e
JOIN projects p ON e.project_id = p.id
WHERE 
    e.timestamp >= NOW() - INTERVAL '1 hour'
    AND e.level = 'error'
    AND p.organization_id = 'org-uuid-here'
GROUP BY p.name
ORDER BY total_errors DESC
LIMIT 10;
