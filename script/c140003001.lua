--도와줘 고양이
local s,id=GetID()
function s.initial_effect(c)
	--1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
	--2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.pcon)
	e3:SetTarget(s.tktg)
	e3:SetOperation(s.tkop)
	c:RegisterEffect(e3)
end

--1번 효과
--도와줘 시스템 메세지용
s.helpers={
	[140003000]="개",
	[140003001]="고양이",
	[140003002]="새",
	[140003003]="토끼",
}
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x301) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.Announce("도와줘 "..(s.helpers[id] or "몬스터").."가 도움을 요청했다!")
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=nil
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 then
		Duel.ConfirmDecktop(tp,3)
		local g=Duel.GetDecktopGroup(tp,3)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:IsExists(s.spfilter,1,nil,e,tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
			Duel.DisableShuffleCheck()
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then tc=sg:GetFirst() end
		end
		Duel.ShuffleDeck(tp)
	end
	if tc then
		--도와줘 시스템 메세지
		Duel.Announce("도와줘 "..(s.helpers[tc:GetCode()] or "몬스터").."가 나타났다!")
	else
		Duel.Announce("도움은 오지 않았다!")
	end
	--특소 제약
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsSetCard(0x301)
end

--2번 효과
function s.pcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_PAIR)
end
s.token=140003014
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,s.token,0x301,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,s.token,0x301,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	local token=Duel.CreateToken(tp,s.token)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		--토큰 소재 제약
		for _,code in ipairs({EFFECT_CANNOT_BE_SYNCHRO_MATERIAL,EFFECT_CANNOT_BE_LINK_MATERIAL,
				EFFECT_CANNOT_BE_ACCESS_MATERIAL,EFFECT_CANNOT_BE_PAIRING_MATERIAL}) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(code)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
	end
	Duel.SpecialSummonComplete()
end
