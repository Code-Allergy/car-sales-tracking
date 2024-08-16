SELECT cron.schedule(
    'rebuild_demo',
    '0 */3 * * *',
    $$
    SELECT demo_rebuild();
    SELECT demo_populate();
    $$
);