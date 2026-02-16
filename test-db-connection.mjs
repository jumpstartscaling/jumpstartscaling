import pg from 'pg';

const dbUrl = process.env.DATABASE_URL || 'postgres://spark-god-mode:eEQme6YUWIMYP20bUjf6ZE75BX1HrVMXv9Z5TBsWr8NP94JxjsdnW0NB8vvczHlC@localhost:5433/arc-net';

console.log('Testing connection to:', dbUrl.replace(/:[^:]*@/, ':****@'));

const pool = new pg.Pool({ connectionString: dbUrl });

try {
    const result = await pool.query('SELECT NOW() as time, current_database() as db, version() as ver');
    console.log('\n🎉 DATABASE CONNECTION SUCCESS!\n');
    console.log('Database:', result.rows[0].db);
    console.log('Time:', result.rows[0].time);
    console.log('PostgreSQL:', result.rows[0].ver.substring(0, 60));

    // Count tables
    const tables = await pool.query("SELECT COUNT(*) as count FROM information_schema.tables WHERE table_schema='public'");
    console.log('Tables:', tables.rows[0].count);

    await pool.end();
    process.exit(0);
} catch (error) {
    console.error('\n❌ CONNECTION FAILED\n');
    console.error('Error:', error.message);
    console.error('Code:', error.code);
    console.error('Detail:', error.detail || 'No additional details');
    process.exit(1);
}
