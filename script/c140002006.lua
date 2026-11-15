--공생하는 벨루티나 모스
local s,id=GetID()
function s.initial_effect(c)
	-- ①: 자신 필드에 빛 속성의 "벨루티나" 몬스터가 존재할 경우, 패 / 묘지에서 특수 소환
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1, id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②: 전투로 상대 몬스터를 파괴하고 묘지로 보냈을 경우, LP 500 회복
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1, id+100)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end

-- "벨루티나" 테마군 코드 (기존 카드들과 맞춰서 수정)
s.listed_series={0x305}

------------------------------------------------------------------
-- ① 효과 관련 함수
------------------------------------------------------------------
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x305) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 자신 필드에 빛 속성의 "벨루티나" 몬스터가 존재할 경우
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 턴 종료시까지 자신은 곤충족 몬스터밖에 엑스트라 덱에서 특수 소환할 수 없다
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetDescription(aux.Stringid(id,2)) -- 곤충족 외 엑스트라 덱 특수 소환 제한 텍스트
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.splimit(e,c,sumtp,sumpos,sumplayer,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT)
end

------------------------------------------------------------------
-- ② 효과 관련 함수
------------------------------------------------------------------
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 이 카드가 전투로 상대 몬스터를 파괴하고 묘지로 보냈을 경우
	return aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) and bc and bc:IsControler(1-tp)
end

function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end