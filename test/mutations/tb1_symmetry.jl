const TB1_SYMMETRY_MUTANT = Mutant(
    "TB1 N2 drop_point_on_left_symmetrization",
    "src/verifiers/ldt.jl",
    "elseif right_type in (:ALine, :DLine) && left_type == :Point\n        return _line_point_test(params, right_type, right_question, left_question,\n                                right_answer, left_answer)",
    "elseif false\n        return _line_point_test(params, right_type, right_question, left_question,\n                                right_answer, left_answer)",
    "tb1_decider_rejections")
