import eventHub from '~/blob/components/eventhub';
import { SNIPPET_MEASURE_BLOBS_CONTENT } from '~/performance/constants';

export default {
  props: {
    content: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    fileName: {
      type: String,
      required: false,
      default: '',
    },
  },
  mounted() {
    eventHub.$emit(SNIPPET_MEASURE_BLOBS_CONTENT);
  },
};
