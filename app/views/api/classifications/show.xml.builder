xml.instruct!
xml.classification do |classification|
	classification.id @classification.id
	classification.zooniverse_user_id @classification.zooniverse_user_id
	classification.subjects do |subjects|
		@classification.subjects.each do |a|
			subjects.subject do |subject|
				subject.id a.id
				subject.location a.location
				subject.external_ref a.external_ref
			end
		end
		classification.annotations do |annotations|
			@classification.annotations.each do |a|
				annotations.annotation do |annotation|
					annotation.id a.id
					annotation.task_id a.task_id
					annotation.value a.value
				end
			end
		end
	end
end