/* eslint-disable no-console */
import { ErrorWithStack } from 'jest-util';

const failOnConsole = method => {
  beforeEach(() => {
    jest.spyOn(console, method);
  });

  afterEach(() => {
    // Some tests remove the mock so, let's not do anything in those cases.
    if (!console[method].mock) {
      return;
    }

    const callArgs = console[method].mock.calls[0];

    console[method].mockClear();

    if (callArgs) {
      throw new ErrorWithStack(
        `Unexpected call to console.${method}: ${callArgs.join(' ')}`,
        failOnConsole,
      );
    }
  });
};

export const failOnConsoleError = () => failOnConsole('error');

export const failOnConsoleWarn = () => failOnConsole('warn');
