import graphql from 'graphql';
import * as AST from '../ast';
import type { GlitchContext } from '../types';

export const generateTypes = (context: GlitchContext): AST.Program => {
  const program = AST.b.program([
    AST.b.importDeclaration([AST.b.importNamespaceSpecifier(AST.b.identifier('base'))], AST.b.stringLiteral('./base')),
    AST.b.importDeclaration(
      [AST.b.importSpecifier(AST.b.identifier('MakeRequired'))],
      AST.b.stringLiteral('@withglyph/glitch/runtime'),
    ),
  ]);

  for (const { name, documentNode } of context.artifacts) {
    const path: string[] = [];
    const requiredPath: string[] = [''];

    graphql.visit(documentNode, {
      enter(node) {
        if (node.kind === 'Field') {
          path.push(node.name.value);

          if (node.directives?.some(({ name }) => name.value === '_required')) {
            requiredPath.push(path.join('.'));
          }
        }
      },

      leave(node) {
        if (node.kind === 'Field') {
          path.pop();
        }
      },
    });

    program.body.push(
      AST.b.exportNamedDeclaration(
        AST.b.tsTypeAliasDeclaration(
          AST.b.identifier(name),
          AST.b.tsTypeReference(
            AST.b.identifier('MakeRequired'),
            AST.b.tsTypeParameterInstantiation([
              AST.b.tsTypeReference(AST.b.identifier(`base.${name}`)),
              AST.b.tsUnionType(requiredPath.map((path) => AST.b.tsLiteralType(AST.b.stringLiteral(path)))),
            ]),
          ),
        ),
      ),
    );
  }

  return program;
};
