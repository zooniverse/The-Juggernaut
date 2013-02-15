xml.instruct!
xml.annotation do |annotation|
	annotation.id @annotation.id
	annotation.zooniverse_user_id @annotation.classification.zooniverse_user_id
	annotation.task_id @annotation.task_id
	annotation.subjects do |subjects|
		@annotation.classification.subjects.each do |a|
			subjects.subject do |subject|
				subject.id a.id
				subject.location a.location
			end
		end
	end
end