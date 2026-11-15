--우화를 위한 기다림
local s,id=GetID()
function s.initial_effect(c)

	-- ①: 카드 발동 시 처리 (서치 및 1~2턴째 추가 일반 소환)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②: 마법 & 함정 존에 존재하는 한, 상대 몬스터는 공격 선언할 수 없다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0, LOCATION_MZONE)
	c:RegisterEffect(e2)

	-- ③-1: 상대 엔드 페이즈마다 카운트 누적
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.ctcon)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)

	-- ③-2: 상대 턴에서 세어서 3턴 후의 상대 엔드 페이즈에 발동 (파괴 및 드로우)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

-- "벨루티나 코쿤"의 카드 번호 (실제 카드 번호로 변경 필요)
local CARD_COCOON=140002009 

------------------------------------------------------------------
-- ① 효과 관련 함수 (발동 시 서치 & 1~2턴째 추가 일소)
------------------------------------------------------------------
function s.thfilter(c)
	return c:IsCode(140002001) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	-- 덱에서 "벨루티나 코쿤" 1장을 패에 넣을 수 있다
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
		end
	end

	-- 듀얼 개시 후 1턴 또는 2턴째의 메인 페이즈에 발동했다면
	local turn=Duel.GetTurnCount()
	local ph=Duel.GetCurrentPhase()
	if (turn==1 or turn==2) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) then
		if Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND,0,1,nil,true,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sumg=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND,0,1,1,nil,true,nil)
			local sc=sumg:GetFirst()
			if sc then
				Duel.Summon(tp,sc,true,nil)
			end
		end
	end
end

------------------------------------------------------------------
-- ③ 효과 관련 함수 (상대 턴 기준 3턴 후 자괴 및 드로우)
------------------------------------------------------------------
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 상대 엔드 페이즈마다 플래그 카운트 1 증가 (최대 3까지 누적)
	if c:GetFlagEffect(id)<3 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local act_turn=e:GetHandler():GetFlagEffectLabel(id)
	if not act_turn then return false end
	
	-- 서로의 턴을 합쳐서 정확히 3턴이 경과한 엔드 페이즈
	return (Duel.GetTurnCount()-act_turn)>=3	
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end