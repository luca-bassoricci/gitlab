import { ignoreConsoleWarn } from './fail_on_console';

export const ignoreMonacoInitWarnings = () => {
  ignoreConsoleWarn(
    'Could not create web worker(s). Falling back to loading web worker code in main thread, which might cause UI freezes. Please see https://github.com/Microsoft/monaco-editor#faq',
    'You must define a function MonacoEnvironment.getWorkerUrl or MonacoEnvironment.getWorker',
  );
};
