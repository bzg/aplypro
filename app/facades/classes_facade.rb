# frozen_string_literal: true

class ClassesFacade
  def initialize(classes)
    @classes = classes
  end

  def nb_students_per_class
    @nb_students_per_class ||= compute_nb_students_per_class
  end

  def nb_attributive_decisions_per_class
    @nb_attributive_decisions_per_class ||= compute_nb_attributive_decisions_per_class
  end

  def nb_ribs_per_class
    @nb_ribs_per_class ||= compute_nb_ribs_per_class
  end

  def nb_pfmps(class_id, state)
    pfmps_by_classe_and_state.dig(class_id, state.to_s) || 0
  end

  private

  def compute_nb_students_per_class
    Schooling.where(classe_id: @classes.pluck(:id))
             .group(:classe_id)
             .count
  end

  def compute_nb_attributive_decisions_per_class
    Schooling.where(classe_id: @classes.pluck(:id))
             .with_attributive_decisions
             .group(:classe_id)
             .count
  end

  def compute_nb_ribs_per_class
    Rib.joins(student: :schoolings)
       .where(schoolings: { classe_id: @classes.pluck(:id) })
       .group("schoolings.classe_id")
       .count
  end

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
