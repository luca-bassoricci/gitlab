import { Node } from '@tiptap/core';

export default Node.create({
  name: 'subscript',

  inline: true,

  group: 'inline',

  addAttributes() {
    return {
      textContent: {
        default: null,
        parseHTML: (element) => {
          return {
            textContent: element.textContent,
          };
        },
      },
    };
  },

  parseHTML() {
    return [
      {
        tag: 'sub',
      },
    ];
  },

  renderHTML({ node }) {
    return ['sub', {}, node.attrs.textContent];
  },
});
