--오드라이트 글래스윙
local s,id=GetID()
function s.initial_effect(c)
	--싱크로 소환
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()	
	--덱으로 되돌리고
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--묘지 회수
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	cyan.JustSearch(e2,LOCATION_GRAVE,Card.IsType,TYPE_SPELL)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (Duel.IsExistingMatchingCard(s.chk,tp,0,LOCATION_MZONE,1,nil) or not c:IsRace(RACE_ROCK))
end
function s.chk(c)
	return c:IsFaceup() and not (c:IsAttack(0) and c:IsDefense(0))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA) then
		if tc:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
			Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
		if tc:IsRace(RACE_ROCK) then
			local g1=Duel.SelectMatchingCard(tp,s.chk,tp,0,LOCATION_MZONE,1,1,nil)
			local tc1=g1:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc1:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE)
			tc1:RegisterEffect(e2)
		end
	end
end
