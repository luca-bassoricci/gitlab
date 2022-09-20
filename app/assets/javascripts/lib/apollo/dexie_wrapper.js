import { parse } from 'micromatch';
import { db } from './local_db';

export class DexieWrapper {
  constructor(dexie) {}

  async getItem(queryId) {
    console.log('GET ITEM ' + queryId);

    const resultObj = {};
    const selectedQuery = await db.table('queries').get(queryId);
    console.log('Query ', selectedQuery);
    resultObj.ROOT_QUERY = selectedQuery;

    const parseObjectsForRef = async (selObject) => {
      console.log('Parse Object : ', selObject);
      for (const key in selObject) {
        if (Object.prototype.hasOwnProperty.call(selObject, key)) {
          if (selObject[key]) {
            if (selObject[key].__ref) {
              const pathId = selObject[key].__ref;
              const pathParts = pathId.split(':');

              if (!resultObj[pathId]) {
                const selectedEntity = await db
                  .table(pathParts[0].toLowerCase())
                  .get(pathId.substr(pathParts[0].length + 1));

                console.log('Found Entity : ', selectedEntity);

                if (selectedEntity) {
                  await parseObjectsForRef(selectedEntity);
                  resultObj[pathId] = selectedEntity;
                }
              }
            } else if (typeof selObject[key] === 'object') {
              await parseObjectsForRef(selObject[key]);
            } else if (Array.isArray(selObject[key])) {
              console.log('Parse Array');
              const subentities = selObject[key].map(async (item) => {
                await parseObjectsForRef(item);
              });
            }
          }
        }
      }
    };

    await parseObjectsForRef(resultObj.ROOT_QUERY);

    console.log('FINAL RESULT OBJECT : ', resultObj);

    return resultObj;
  }

  removeItem(key) {
    console.log('REMOVE ITEM ' + key);
  }

  setItem(key, value) {
    console.log('SET ITEM ' + key + ' - ', value);
    this.setQueryResults(key, value);

    // db.issues.add(value);
  }

  setQueryResults(queryId, results) {
    for (const id in results) {
      console.log('PROP : ', id, results[id]);
      const objectType = id.split(':')[0];
      if (objectType == 'ROOT_QUERY') {
        console.log('Save Query ' + queryId + ' - ', results[id]);
        db.table('queries').put(results[id], queryId);
      } else {
        console.log('Add : ' + objectType.toLowerCase() + ' = ', results[id]);
        db.table(objectType.toLowerCase()).put(results[id], id);
      }
    }
  }
}
