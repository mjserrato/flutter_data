import 'package:flutter_data/flutter_data.dart';
import 'package:test/test.dart';

import 'models/family.dart';
import 'models/person.dart';
import 'setup.dart';

void main() async {
  test('no id', () {
    final manager = TestDataManager(null);
    expect(DataId(null, manager).id, isNull);
  });

  test('produces a new key', () {
    final manager = TestDataManager(null);
    var dataId = manager.dataId<Person>('1');
    expect(dataId.key, startsWith('people#'));
  });

  test('reuses a provided key', () {
    final manager = TestDataManager(null);
    var dataId = manager.dataId<Person>('29', key: 'people#78a92b');
    expect(dataId.key, 'people#78a92b');
    expect(dataId.id, '29');
  });

  test('model is set only if manager is null', () {
    final manager = TestDataManager(null);
    var dataId =
        DataId<Person>('1', null, model: Person(id: '1', name: "zzz", age: 7));
    expect(dataId.model, isNotNull);

    var dataId2 = manager.dataId<Person>('2',
        model: Person(id: '2', name: "zzz", age: 7));
    expect(dataId2.model, isNull);
  });

  test('reuses a key', () {
    final manager = TestDataManager(null);
    var dataId = manager.dataId<Person>('1', key: 'people#a5a5a5');
    expect(dataId.key, 'people#a5a5a5');
  });

  test('should reuse key', () {
    var manager = injection.locator<DataManager>();
    var repository = injection.locator<Repository<Person>>();

    // id-less person
    var p1 = Person(name: "Frank", age: 20).init(repository);
    expect(repository.localAdapter.box.keys.length, 1);

    // person with new id, reusing existing key
    manager.dataId<Person>('221', key: p1.key);
    var p2 = Person(id: '221', name: 'Frank2', age: 32).init(repository);
    expect(p1.key, p2.key);

    expect(repository.localAdapter.box.keys.length, 1);

    // another person, without reusing key
    Person(id: '222', name: 'Frank3', age: 76).init(repository);
    expect(repository.localAdapter.box.keys.length, 2);
  });

  // static utils

  test('getType', () {
    expect(DataId.getType<Person>(), 'people');
    expect(DataId.getType('Family'), 'families');
  });

  test('byKeys', () {
    final manager = TestDataManager(null);
    // including ids that contain '#' (also used in internal format)
    manager.keysBox.put('people#p#1', 'people#a1a1a1');
    manager.keysBox.put('people#2', 'people#b2b2b2');
    manager.keysBox.put('people#3', 'people#c3c3c3');

    var list = DataId.byKeys<Person>(
        ['people#a1a1a1', 'people#b2b2b2', 'people#c3c3c3'], manager);
    expect(list, [
      manager.dataId<Person>('p#1'),
      manager.dataId<Person>('2'),
      manager.dataId<Person>('3')
    ]);
  });

  test('byKey', () {
    final manager = TestDataManager(null);
    manager.keysBox.put('families#3', 'families#c3c3c3');

    var dataId = DataId.byKey<Family>('families#c3c3c3', manager);
    expect(dataId, manager.dataId<Family>('3'));
    expect(dataId, isNot(manager.dataId<Person>('3')));
  });

  test('equals', () {
    final manager = TestDataManager(null);
    expect(manager.dataId<Person>("1"), manager.dataId<Person>("1"));
  });

  test('not equals', () {
    final manager = TestDataManager(null);
    expect(manager.dataId<Person>("1"), isNot(manager.dataId<Family>("1")));
  });
}