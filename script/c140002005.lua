-- 포식당하는 벨루티나 모스
local s,id=GetID()
function s.initial_effect(c)
	-- ①: 패에서 특수 소환하는 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②: 어둠 속성 "벨루티나" 몬스터의 효과로 파괴되어 묘지로 보내졌을 경우
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, id+100)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

-- "벨루티나" 테마군 정의 (상수 값은 프로젝트에 맞게 공통으로 관리)
s.listed_series={0x305}

------------------------------------------------------------------
-- ① 효과 관련 함수
------------------------------------------------------------------
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x305) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 자신 필드에 어둠 속성의 "벨루티나" 몬스터가 존재할 경우
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
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re and re:GetHandler()
	-- 이 카드가 효과로 파괴되어 묘지로 보내졌으며, 
	-- 그 효과의 발동한 카드가 어둠 속성의 "벨루티나" 몬스터일 경우
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and rc and rc:IsSetCard(0x305) and rc:IsAttribute(ATTRIBUTE_DARK) and rc:IsMonster()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)	
	Duel.Draw(tp,1,REASON_EFFECT)
end