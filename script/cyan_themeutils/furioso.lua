--앵화난무용 유틸
EFFECT_SET_BASE_ATTACK_FINAL=EFFECT_SET_BASE_ATTACK
EFFECT_SET_BASE_DEFENSE_FINAL=EFFECT_SET_BASE_DEFENSE
--해금 체크
UNLOCK_COMPLETE=103553000


--"방랑의 이나리소녀"를 제외하고 패 / 덱 / 묘지가 하이랜더 상태인지 체크
function cyan.IsUnlockState(e,tp)
	return Duel.IsPlayerAffectedByEffect(tp,UNLOCK_COMPLETE)
end

function cyan.hlchk(c,tp)
	if c:IsCode(103553000) then return false end
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,c,c:GetCode())
end

--앵화난무 스택 적립
function cyan.AddFuriosoStack(tp,ct)
	local t=Duel.AddPlayerCounter(tp,0x2,ct)
	Duel.BreakEffect()
	if t>0 and Duel.GetPlayerCounter(tp,0x2)==6 then
		local token=Duel.CreateToken(tp,103553002)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then
			local tc=Duel.SelectMatchingCard(tp.aux.TRUE,tp,LOCATION_SZONE,0,1,1,nil)
			if tc:GetCount()>0 then
				Duel.SendtoHand(tc,nil,REASON_RULE)
			end
		end
		Duel.MoveToField(token,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
	if Duel.GetPlayerCounter(tp,0x2)>=9 then
		local tc1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,103553002):GetFirst()
		if tc then Duel.RaiseEvent(tc,103553002,tp,nil,nil,nil,nil) end
	end
end