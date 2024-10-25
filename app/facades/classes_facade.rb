# frozen_string_literal: true

class ClassesFacade
  def initialize(classes)
    @classes = classes.includes(
      :school_year,
      students: :ribs,
      schoolings:
        [
          { attributive_decision_attachment: :blob },
          { abrogation_decision_attachment: :blob }
        ]
    )
  end

  def nb_students_per_class
    @nb_students_per_class ||= @classes
                               .joins(:students)
                               .reorder(nil)
                               .group(:"classes.id")
                               .count
  end

  def nb_attributive_decisions_per_class
    @nb_attributive_decisions_per_class ||= @classes
                                            .joins(:schoolings)
                                            .merge(Schooling.with_attributive_decisions)
                                            .group(:"classes.id")
                                            .count
  end

  def nb_ribs_per_class
    @nb_ribs_per_class ||= @classes
                           .joins(students: :ribs)
                           .where(ribs: { archived_at: nil })
                           .reorder(nil)
                           .group(:"classes.id")
                           .distinct
                           .count(:"students.id")
  end

  def nb_pfmps(class_id, state)
    pfmps_by_classe_and_state.dig(class_id, state.to_s) || 0
  end

  def nb_payment_requests(class_id, states)
    ASP::PaymentRequest.latest_per_pfmp
                       .joins(pfmp: { schooling: :classe })
                       .where(classes: { id: class_id })
                       .in_state(states)
                       .count
  end

  private

  def pfmps_by_classe_and_state
    @pfmps_by_classe_and_state ||= group_pfmps_by_classe_and_state
  end

  def group_pfmps_by_classe_and_state
    counts = {}

    Pfmp.joins(:schooling)
        .joins("LEFT JOIN pfmp_transitions ON pfmp_transitions.pfmp_id = pfmps.id AND pfmp_transitions.most_recent = true") # rubocop:disable Layout/LineLength
        .where(schoolings: { classe_id: @classes.pluck(:id) })
        .group("schoolings.classe_id", "COALESCE(pfmp_transitions.to_state, 'pending')")
        .count
        .each do |(class_id, state), count|
      counts[class_id] ||= {}
      counts[class_id][state.presence || "pending"] = count
    end

    counts
  end
end
