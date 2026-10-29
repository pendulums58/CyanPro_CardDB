--´ÜÂ¦ ÄÚµå
COMPANION_COMPLETE=101223031
COMPANION_SELECT=101223032


--´ÜÂ¦ È¸¼ö È¿°ú
function cyan.companiontheffect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTarget(cyan.comptg)
	e0:SetOperation(cyan.compop)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e1)	
	local e2=e0:Clone()
	e2:SetRange(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	local e3=e0:Clone()
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	local e4=e0:Clone()
	e4:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e4)
end
function cyan.comptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (c:IsLocation(LOCATION_ONFIELD) or c:IsAbleToHand()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cyan.compop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
