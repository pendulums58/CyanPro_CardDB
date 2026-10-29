--운명을 거래하는 행상인
local s,id=GetID()
function s.initial_effect(c)
	--자체 특수 소환
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--거래를 합시다
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,e:GetHandler(),tp) end
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsAttack(1400) or c:IsDefense(1400)) and c:IsAbleToRemoveAsCost()
		and Duel.GetLocationCount(tp,LOCATION_MZONE,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,3,nil) end
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	s.purchase(tp,true)
end
function s.purchase(tp,chk)
	--거래 개시
	--거래 풀에서 무작위로 3개 선택(겹치지 않도록)
	--카드 등급은 커먼, 언커먼, 레어로 구분하여 각 등급별 확률 적용
	
	-- 커먼 등급 카드
	-- 오리카
	-- 범용 태그에서 : 강건한 수호의 적수, 점적천석의 저항자, 오더메이드 워블러, 뱀부스피어 제너럴
	local common={101223078,101223134,101223168,101223186,101223228,67169062,85852291,67616300,80036543,9064354}
	-- 언커먼 등급 카드
	-- 비오리카
	-- 패트랩 : 하루 우라라, 증식의 G, 유령토끼, 저택 와라시, 이펙트 뵐러, 무한포영
	-- 케어 카드 : 무덤의 지명자, 말살의 지명자
	-- 강력 범용 마법 : 죽은 자의 소생, 번개, 해피의 깃털
	-- 엑스트라 덱 몬스터 : 
	-- 오리카
	-- 패트랩 : 영원 커넥터, 소원 어센더, 마나 페네트레이터
	-- 케어 카드 : 전생의 유언
	local uncommon={14558129,23434538,59438932,73642298,97268402,10045474,24224830,65681983,83764718,12580477,18144506,101223222,101223223,101223139}
	
	-- 레어 등급 카드
	-- 오리카
	-- 상위 패트랩 : 드림 오브 크리스탈
	-- 비오리카
	-- 금지 카드 : 대 한파, 댄디라이언, 이차원으로부터의 귀환, 허리케인
	local rare={101223183,60682203,15341821,27174286,42703248}
	-- 커먼 확률 60%, 언커먼 확률 30%, 레어 확률 10%
	local goods=Group.CreateGroup()
	local rarity=0
	local maxrare=0
	while #goods<3 do
		local gacha=Duel.GetRandomNumber(1,100)
		if gacha<=60 then
			rarity=1
			if maxrare < rarity then
				maxrare=rarity
			end
		elseif gacha<=90 then
			rarity=2
			if maxrare < rarity then
				maxrare=rarity
			end
		else
			rarity=3
			if maxrare < rarity then
				maxrare=rarity
			end
		end
		local token=0
		if rarity==1 then
			token=common[Duel.GetRandomNumber(1,#common)]
		elseif rarity==2 then
			token=uncommon[Duel.GetRandomNumber(1,#uncommon)]
		elseif rarity==3 then
			token=rare[Duel.GetRandomNumber(1,#rare)]
		end
		if not goods:IsExists(Card.IsCode,1,nil,token) then
			token=Duel.CreateToken(tp,token)
			goods:AddCard(token)
		end
	end
	if chk==true then
		local reroll=Duel.CreateToken(tp,101223247)
		goods:AddCard(reroll)
	end
	if maxrare == 3 then
		local a = Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif maxrare == 2 then
		local a = Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		local a = Duel.SelectOption(tp,aux.Stringid(id,3))
	end
	 local g=goods:Select(tp,1,1,nil)
	if g:GetFirst():IsCode(101223247) then
		s.purchase(tp,false)
	else
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end	
	end
	
	 
end
function s.rmfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end