--그늘막의 벨루티나 포레스트
local s,id=GetID()
function s.initial_effect(c)
	-- ★ 필수: 필드 마법 카드의 발동 처리 (이 코드가 있어야 패에서 정상적으로 앞면 표시로 발동됩니다)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 발동 시 처리 등 추가 효과가 필요하다면 여기에 작성 (현재는 기본 필드 마법룰 적용)
	-- 공통 필드 마법 효과 (자신 필드의 모든 몬스터 공/수 상승 등은 필요시 추가 가능)

	-- ①: 1턴에 1번, "벨루티나 코쿤"이 필드를 벗어날 경우, 대신 LP를 1000 지불할 수 있다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	
	-- 파괴 외의 이탈(바운스, 제외 등)도 치환하기 위한 사전 체크 이벤트
	local e1_sub=Effect.CreateEffect(c)
	e1_sub:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1_sub:SetCode(EVENT_LEAVE_FIELD_P)
	e1_sub:SetRange(LOCATION_FZONE)
	e1_sub:SetOperation(s.regop)
	c:RegisterEffect(e1_sub)

	-- ②: 필드의 이 카드가 상대에 의해 필드에서 벗어났을 경우에 발동할 수 있다 (패/묘지 서치 + 발동 제한)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- "벨루티나 코쿤"의 카드 번호 (실제 카드 번호로 변경 필요)
local CARD_COCOON=140002001 

------------------------------------------------------------------
-- ① 효과 관련 함수 (코쿤 보호 치환)
------------------------------------------------------------------
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE+LOCATION_SZONE)
		and c:IsCode(CARD_COCOON) and not c:IsReason(REASON_REPLACE)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	eg:ForEach(function(tc)
		if s.repfilter(tc,tp) then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.CheckLPCost(tp,1000) and eg:IsExists(s.repfilter,1,nil,tp) 
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
		return true
	end
	return false
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,1000)
	-- LP를 지불하는 대신 코쿤의 파괴/이탈을 무효화하고 보호합니다.
end

------------------------------------------------------------------
-- ② 효과 관련 함수 (상대에 의한 이탈 서치 & 발동 제한)
------------------------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 필드의 이 카드가 상대에 의해 필드에서 벗어났을 경우
	return c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.thfilter(c)
	return c:IsCode(CARD_COCOON) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,tc)
			-- 이 턴, 자신은 이 효과로 패에 넣은 카드 및 그 동명 카드의 발동을 할 수 없다
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end