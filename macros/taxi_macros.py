from __future__ import annotations

from sqlglot import exp

from sqlmesh import macro


@macro()
def safe_divide(evaluator, numerator: exp.Expression, denominator: exp.Expression) -> exp.Case:
    return exp.Case(
        ifs=[exp.If(this=exp.EQ(this=denominator.copy(), expression=exp.Literal.number(0)), true=exp.null())],
        default=exp.Div(this=numerator.copy(), expression=denominator.copy()),
    )
