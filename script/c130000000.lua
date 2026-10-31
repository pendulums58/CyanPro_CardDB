--창공 유목민, 요리온
local s,id=GetID()
function s.initial_effect(c)
	--단짝 세팅
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_DECK)
	e0:SetTarget(s.comptg)
	e0:SetOperation(s.compop)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetRange(LOCATION_HAND)
	c:RegisterEffect(e1)	
	--깜빡이 효과
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.comptg(e,tp,ep,eg,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,COMPANION_COMPLETE)
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK+LOCATION_HAND,0,nil)==60
		and Duel.GetTurnCount()==1 end
end
function s.compop(e,tp,ep,eg,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,COMPANION_COMPLETE) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		cyan.companiontheffect(c)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(COMPANION_COMPLETE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)
		Duel.Announce("[p"..tp.."] -  '[c=cyan]창공 유목민,[/c][c=white] 요리온[/c]'을 단짝으로 지정했습니다.")
		if not c:IsLocation(LOCATION_HAND) then 
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,c)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.tgfilter,1,nil,tp) and rp==1-tp and not c:IsStatus(STATUS_CHAINING)
end
function s.tgfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
function s.sptg(e,tp,ep,eg,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)	
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,1,1,c)
		if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			local tc=g:GetFirst()
			if tc and tc:IsType(TYPE_MONSTER) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else
				if tc and tc:IsType(TYPE_MONSTER) then 
					Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
				elseif tc and tc:IsType(TYPE_FIELD) then
					Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				elseif tc then
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				end
			end
		end
	end
end