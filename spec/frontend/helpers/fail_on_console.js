/* eslint-disable no-console */
import { isString } from 'lodash';
import { ErrorWithStack } from 'jest-util';

const GLOBAL_KEY = '$_fail_on_console_ignore_';

const setGlobalIgnore = (method, messages) => {
  const key = `${GLOBAL_KEY}${method}`;

  global[key] = (global[key] || []).concat(messages);
};

const getGlobalIgnore = method => {
  const key = `${GLOBAL_KEY}${method}`;

  return global[key] || [];
};

const throwError = (method, message) => {
  throw new ErrorWithStack(`Unexpected call to console.${method}: ${message}`, throwError);
};

const isIgnored = (message, ignoredMessages) => {
  return ignoredMessages.some(x => {
    if (isString(x)) {
      return message === x;
    } else if (x.test) {
      return x.test(message);
    }

    return false;
  });
};

const getFirstMessage = (consoleMethod, ignoredMessages) => {
  if (!consoleMethod.mock) {
    return null;
  }

  return consoleMethod.mock.calls
    .map(args => args.join(' '))
    .find(message => !isIgnored(message, ignoredMessages));
};

const failOnConsole = method => {
  beforeEach(() => {
    setGlobalIgnore(method, []);

    jest.spyOn(console, method);
  });

  afterEach(() => {
    const ignoredMessages = getGlobalIgnore(method);

    const message = getFirstMessage(console[method], ignoredMessages);

    if (message) {
      throwError(method, message);
    }
  });
};

export const ignoreConsoleError = (...messages) => setGlobalIgnore('error', messages);

export const ignoreConsoleWarn = (...messages) => setGlobalIgnore('warn', messages);

export const failOnConsoleError = () => failOnConsole('error');

export const failOnConsoleWarn = () => failOnConsole('warn');
