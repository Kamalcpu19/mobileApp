const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const useWindowsAuth = process.env.DB_USE_WINDOWS_AUTH === 'true';
const sql = useWindowsAuth ? require('mssql/msnodesqlv8') : require('mssql');
const { convertPostgresToSqlServer } = require('./queryConverter');

const poolOptions = {
  max: 10,
  min: 0,
  idleTimeoutMillis: 30000,
};

function buildConfig(targetDatabase) {
  const dbName = targetDatabase || process.env.DB_NAME || 'workshop_advisor';
  const server = process.env.DB_SERVER || 'localhost';

  if (useWindowsAuth) {
    return {
      driver: 'msnodesqlv8',
      connectionString:
        'Driver={ODBC Driver 17 for SQL Server};' +
        `Server=${server};` +
        `Database=${dbName};` +
        'Trusted_Connection=Yes;' +
        'TrustServerCertificate=Yes;' +
        'Encrypt=No;',
      pool: poolOptions,
    };
  }

  return {
    user: process.env.DB_USER || 'sa',
    password: process.env.DB_PASSWORD,
    server,
    database: dbName,
    port: parseInt(process.env.DB_PORT || '1433', 10),
    options: {
      encrypt: process.env.DB_ENCRYPT === 'true',
      trustServerCertificate: process.env.DB_TRUST_CERT !== 'false',
      enableArithAbort: true,
    },
    pool: poolOptions,
  };
}

let poolPromise;

async function getPool() {
  if (!poolPromise) {
    poolPromise = sql.connect(buildConfig());
  }
  return poolPromise;
}

async function ensureDatabase() {
  const dbName = process.env.DB_NAME || 'workshop_advisor';
  const masterPool = await sql.connect(buildConfig('master'));
  const safeName = dbName.replace(/'/g, "''");
  const result = await masterPool.request().query(
    `SELECT name FROM sys.databases WHERE name = N'${safeName}'`,
  );

  if (result.recordset.length === 0) {
    await masterPool.request().query(`CREATE DATABASE [${dbName.replace(/\]/g, '')}]`);
    console.log(`Created database: ${dbName}`);
  }

  await masterPool.close();
}

function inferSqlType(value) {
  if (value === null || value === undefined) return sql.NVarChar;
  if (typeof value === 'boolean') return sql.Bit;
  if (typeof value === 'number') {
    return Number.isInteger(value) ? sql.Int : sql.Decimal(18, 2);
  }
  if (value instanceof Date) return sql.DateTime2;
  if (typeof value === 'string' && value.length > 4000) return sql.NVarChar(sql.MAX);
  return sql.NVarChar;
}

async function query(text, params = []) {
  const pool = await getPool();
  let convertedSql = convertPostgresToSqlServer(text).replace(/@p(\d+)/g, '@param$1');
  const request = pool.request();

  params.forEach((value, index) => {
    const paramName = `param${index + 1}`;
    if (value === null || value === undefined) {
      request.input(paramName, sql.NVarChar, null);
      return;
    }
    request.input(paramName, inferSqlType(value), value);
  });

  const result = await request.query(convertedSql);
  return { rows: result.recordset || [] };
}

async function closePool() {
  if (poolPromise) {
    await sql.close();
    poolPromise = null;
  }
}

module.exports = {
  query,
  closePool,
  ensureDatabase,
  pool: { end: closePool },
  sql,
  buildConfig,
};
