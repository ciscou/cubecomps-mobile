module RoundsHelper
  def round_label(round)
    label_parts = []

    label_parts << round.best_record
    label_parts << "Live!" if round.live?
    label_parts << "Done!" if round.finished?
    label_parts.compact!

    unless label_parts.empty?
      content_tag :span, label_parts.join(" | "), class: "ui-li-count"
    end
  end
end
