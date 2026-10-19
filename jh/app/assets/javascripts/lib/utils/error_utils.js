export class ActiveModelError extends Error {
  constructor(errorAttributeMap = {}, ...params) {
    // Pass remaining arguments (including vendor specific ones) to parent constructor
    super(...params);

    // Maintains proper stack trace for where our error was thrown (only available on V8)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, ActiveModelError);
    }

    this.name = 'ActiveModelError';
    // Custom debugging information
    this.errorAttributeMap = errorAttributeMap;
  }
}
