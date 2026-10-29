--라디언트 효과
EVENT_AMASS=101270000


--자신이 공개되어 있을 경우 컨디션
function cyan.selfpubcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPublic()
end
function cyan.selfnpcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPublic()
end

--이 턴에 공개
function Card.SetPublicThisTurn(c,e)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

