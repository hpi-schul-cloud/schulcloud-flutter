import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:repositories/repositories.dart';
import 'package:source_gen/source_gen.dart';

class EntityGenerator extends GeneratorForAnnotation<Entity> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep _) {
    assert(element is ClassElement, 'Only annotate classes with @Entity.');
    assert(
        element.isPrivate,
        'Only mark private classes with @Entity. The public class will then '
        'get automatically generated for you.');

    var e = element as ClassElement;
    var name = e.displayName.substring(1);
    var actualFields = <FieldElement>{};
    var getterFields = <FieldElement>{};

    for (var field in e.fields) {
      if (field.setter == null) {
        assert(field.getter != null);
        getterFields.add(field);
      } else if (field.getter == null) {
        throw 'Setter-only fields not supported';
      } else
        actualFields.add(field);
    }

    return '''

    @immutable
    @HiveType()
    class $name {
      final Id<$name> id;
      ${_generateFields(actualFields)}

      const $name({
        @required this.id,
        ${_generateArguments(actualFields)}
      }) : assert(id != null),
        ${_generateAssertions(actualFields)};

      bool operator ==(Object other) {
        return other is $name &&
            ${_generateEqualityChecks(actualFields)};
      }

      int get hashCode => hashValues(id, ${actualFields.map((field) => field.displayName).join(', ')});
    }
    ''';
  }

  String _generateFields(Set<FieldElement> fields) {
    return [
      for (var field in fields)
        'final ${field.type.displayName} ${field.displayName};'
    ].join('\n');
  }

  String _generateArguments(Set<FieldElement> fields) {
    return [
      for (var field in fields)
        [if (!_isNullable(field)) '@required ', 'this.${field.displayName},']
            .join()
    ].join('\n');
  }

  String _generateAssertions(Set<FieldElement> fields) {
    return [
      for (var field in fields.where((field) => !_isNullable(field)))
        'assert(${field.displayName} != null)'
    ].join(',\n');
  }

  String _generateEqualityChecks(Set<FieldElement> fields) {
    return [
      for (var field in fields)
        '${field.displayName} == other.${field.displayName}'
    ].join(' &&\n');
  }

  bool _isNullable(FieldElement field) => field.metadata
      .any((annotation) => annotation.element.displayName == 'Nullable');
}

Builder entity(BuilderOptions options) =>
    SharedPartBuilder([EntityGenerator()], 'entity');
