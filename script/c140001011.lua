--스카이워커 스트라토스피어
local s,id=GetID()
function s.initial_effect(c)
	--싱크로 소환
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_THUNDER),1)
	c:EnableReviveLimit()
	--①: 필드의 다른 카드 1장 대상 바운스 + LRM 추가 드로우
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(cyan.SynSSCon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		and (not (re and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(SETCARD_LRM)) or Duel.IsPlayerCanDraw(tp,1)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	if re and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(SETCARD_LRM) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
			and re and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(SETCARD_LRM) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
