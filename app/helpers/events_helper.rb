module EventsHelper
  def event_label(event)
    label_parts = []

    label_parts << event.best_record
    label_parts << "Live!" if event.live?
    label_parts << "Done!" if event.finished?
    label_parts.compact!

    unless label_parts.empty?
      content_tag :span, label_parts.join(" | "), class: "ui-li-count ui-body-inherit"
    end
  end
end
