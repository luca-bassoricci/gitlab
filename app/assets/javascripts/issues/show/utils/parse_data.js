import * as Sentry from '@sentry/browser';
import { sanitize } from '~/lib/dompurify';

// We currently load + parse the data from the issue app and related merge request
let cachedParsedData;

export const parseIssuableData = (el, force) => {
  try {
    if (cachedParsedData && force !== true) return cachedParsedData;

    const parsedData = JSON.parse(el.dataset.initial);
    parsedData.initialTitleHtml = sanitize(parsedData.initialTitleHtml);
    parsedData.initialDescriptionHtml = sanitize(parsedData.initialDescriptionHtml);

    cachedParsedData = parsedData;

    return parsedData;
  } catch (e) {
    Sentry.captureException(e);

    return {};
  }
};
