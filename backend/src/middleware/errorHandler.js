const logger = require('../utils/logger');
const ApiError = require('../utils/ApiError');

function handleCastError(err) {
  return new ApiError(400, `Invalid ${err.path}: ${err.value}`);
}

function handleDuplicateKey(err) {
  const field = Object.keys(err.keyValue || {})[0] || 'field';
  return new ApiError(409, `${field} already in use`);
}

function handleValidationError(err) {
  const messages = Object.values(err.errors).map((e) => e.message);
  return new ApiError(400, messages.join('; '));
}

module.exports = (err, req, res, next) => {
  let error = err;

  if (err.name === 'CastError') error = handleCastError(err);
  if (err.code === 11000) error = handleDuplicateKey(err);
  if (err.name === 'ValidationError') error = handleValidationError(err);
  if (err.name === 'JsonWebTokenError') error = new ApiError(401, 'Invalid token');
  if (err.name === 'TokenExpiredError') error = new ApiError(401, 'Token expired');

  const statusCode = error.statusCode || 500;
  const message = error.isOperational ? error.message : 'Internal server error';

  if (statusCode >= 500) {
    logger.error(`${req.method} ${req.originalUrl}`, err);
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(error.details ? { details: error.details } : {}),
    ...(process.env.NODE_ENV !== 'production' ? { stack: err.stack } : {}),
  });
};
