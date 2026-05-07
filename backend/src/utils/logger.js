const fmt = (level, args) => {
  const ts = new Date().toISOString();
  const msg = args
    .map((a) => (a instanceof Error ? a.stack || a.message : typeof a === 'object' ? JSON.stringify(a) : a))
    .join(' ');
  return `[${ts}] [${level}] ${msg}`;
};

module.exports = {
  info: (...a) => console.log(fmt('INFO', a)),
  warn: (...a) => console.warn(fmt('WARN', a)),
  error: (...a) => console.error(fmt('ERROR', a)),
  debug: (...a) => process.env.NODE_ENV !== 'production' && console.log(fmt('DEBUG', a)),
};
