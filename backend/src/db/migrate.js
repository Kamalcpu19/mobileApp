const fs = require('fs');
const path = require('path');
const db = require('./index');

async function migrate() {
  const schemaPath = path.join(__dirname, 'schema.sql');
  let schema = fs.readFileSync(schemaPath, 'utf8');

  schema = schema
    .replace(/\r\n/g, '\n')
    .replace(/^GO\s*$/gim, '')
    .replace(/RAISERROR[\s\S]*?END\s*/i, '');

  const statements = schema
    .split(/;\s*\n/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0 && !s.startsWith('--'));

  try {
    for (const statement of statements) {
      await db.query(`${statement};`);
    }
    console.log('SQL Server migration completed successfully.');
  } catch (error) {
    console.error('Migration failed:', error.message);
    process.exit(1);
  } finally {
    await db.closePool();
  }
}

migrate();
