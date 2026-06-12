/**
 * Converts PostgreSQL-style queries to SQL Server T-SQL for the existing service layer.
 */
function convertPostgresToSqlServer(text) {
  let sql = text;

  sql = sql.replace(/\bNOW\(\)/gi, 'GETUTCDATE()');
  sql = sql.replace(/\bILIKE\b/gi, 'LIKE');
  sql = sql.replace(/\bTRUE\b/gi, '1');
  sql = sql.replace(/\bFALSE\b/gi, '0');

  sql = sql.replace(
    /(INSERT\s+INTO\s+[\s\S]+?)\s+VALUES\s*\(([\s\S]+?)\)\s+RETURNING\s+\*/gi,
    '$1 OUTPUT INSERTED.* VALUES ($2)',
  );

  sql = sql.replace(
    /(UPDATE\s+[\s\S]+?)\s+RETURNING\s+\*/gi,
    '$1 OUTPUT INSERTED.*',
  );

  const limitMatch = sql.match(/\s+LIMIT\s+(\d+)\s*;?\s*$/i);
  if (limitMatch) {
    const limit = limitMatch[1];
    sql = sql.replace(/\s+LIMIT\s+\d+\s*;?\s*$/i, '');
    if (/ORDER BY/i.test(sql)) {
      sql = `${sql} OFFSET 0 ROWS FETCH NEXT ${limit} ROWS ONLY`;
    } else {
      sql = sql.replace(/^(\s*SELECT\s+)(DISTINCT\s+)?/i, `$1$2TOP ${limit} `);
    }
  }

  sql = sql.replace(/\$(\d+)/g, (_, num) => `@p${num}`);

  return sql.trim();
}

module.exports = { convertPostgresToSqlServer };
