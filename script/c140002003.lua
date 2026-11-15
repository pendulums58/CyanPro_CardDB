--군생하는 벨루티나 엠프레스
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 특수 소환 조건: "벨루티나 - 코쿤"의 효과로만 특수 소환 가능 (통상 소환 불가)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	-- ①: 1턴에 1번만 전투 / 효과로 파괴되지 않는다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)

	-- ②: LP 1000 회복 후, 이 카드 이외의 자신 필드 몬스터 전체 공/수 500(회복치 절반) 상승
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, id)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, id+1)
	e3:SetCondition(s.nscon)
	e3:SetTarget(s.nstg)
	e3:SetOperation(s.nsop)
	c:RegisterEffect(e3)

	-- 전투 파괴 전용 트리거 추가
	local e4=e3:Clone()
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(s.btcon)
	c:RegisterEffect(e4)
end

-- "벨루티나 - 코쿤"의 카드 번호 (실제 카드 번호로 변경 필요)
local CARD_COCOON=140002001 

------------------------------------------------------------------
-- 소환 제한 관련 함수
------------------------------------------------------------------
function s.splimit(e,se,sp,st)
	return se and se:GetHandler():IsCode(CARD_COCOON)
end

------------------------------------------------------------------
-- ① 효과 관련 함수
------------------------------------------------------------------
function s.valcon(e,re,r,rp)
	return (r&(REASON_BATTLE+REASON_EFFECT))~=0
end

------------------------------------------------------------------
-- ② 효과 관련 함수
------------------------------------------------------------------
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 자신은 LP를 1000 회복한다
	if Duel.Recover(tp,1000,REASON_EFFECT)>0 then
		-- 이 카드 이외의 자신 필드의 모든 몬스터
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(500) -- 회복한 수치(1000)의 절반
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e2)
				tc=g:GetNext()
			end
		end
	end
end

------------------------------------------------------------------
-- ③ 효과 관련 함수
------------------------------------------------------------------
function s.nsfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and not c:IsCode(id)
		and (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end

function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nsfilter,1,nil,tp)
end

-- 전투로 파괴되었을 때 (EVENT_BATTLED 감지)
function s.btfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and not c:IsCode(id) and c:IsReason(REASON_BATTLE)
end

function s.btcon(e,tp,eg,ep,ev,re,r,rp)
	local des=Duel.GetBattleMonster(tp)
	-- 내 필드의 다른 몬스터가 전투로 파괴되어 묘지로 가거나 바운스/제외 상태가 되었는지 확인
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a or not d then return false end
	
	local tc=nil
	if a:IsControler(tp) and a:IsStatus(STATUS_BATTLE_DESTROYED) then tc=a end
	if d:IsControler(tp) and d:IsStatus(STATUS_BATTLE_DESTROYED) then tc=d end
	
	return tc and tc~=e:GetHandler() and tc:IsPreviousControler(tp)
end

function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local p=tp
	if Duel.Recover(p,1000,REASON_EFFECT)>0 then
		-- 몬스터 1장의 통상 소환을 실행한다 (추가 소환권 부여 방식)
		-- 패에서 통상 소환 가능한 몬스터가 존재할 경우 실행
		if Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,true,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local g=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,true,nil)
			local tc=g:GetFirst()
			if tc then
				Duel.Summon(tp,tc,true,nil)
			end
		end
	end
end