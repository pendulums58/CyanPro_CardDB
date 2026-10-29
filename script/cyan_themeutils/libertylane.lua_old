

--리버티레인용 함수 리스트

function cyan.AddLibertyLaneEffect(c)
	local e=Effect.CreateEffect(c)
	e:SetDescription(aux.Stringid(101260000,1))
	e:SetCategory(CATEGORY_TOHAND)
	e:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e:SetProperty(EFFECT_FLAG_DELAY)
	e:SetCode(EVENT_TO_GRAVE)
	e:SetCondition(cyan.llsalvcon)
	e:SetTarget(cyan.llsalvtg)
	e:SetOperation(cyan.llsalvop)
	c:RegisterEffect(e)	
end
function cyan.llsalvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ((rp==1-tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE))
		or c:IsReason(REASON_BATTLE))
end
function cyan.llsalvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cyan.llsalvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		if not c:IsPublic() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,c)
		local mt=_G["c"..c:GetCode()]
		mt.llexeff(e,tp,eg,ep,ev,re,r,rp)
	end
end