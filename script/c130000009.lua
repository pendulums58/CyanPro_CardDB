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
		and Duel.GetLocationCount(tp,c)>0
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
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,2,nil) end
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,2,2,nil)
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
	-- 범용 태그에서 : 오더메이드 워블러, 뱀부스피어 제너럴, 태양의 눈물, 정성스러운 빙정화, 엔비오스 단검, 비 갠 후의 하늘에, 슬픔에 잠긴 시스투스, CMY 부적 세트 
	local common={130000008,130000006,130000033,130000034,130000035,130000029,130100000,130000030,130000031,130000032}
	-- 언커먼 등급 카드
	-- 디스턴스 메이커, 전생의 유언, 마음을 굳힌 미스틸테인, 
	local uncommon={130000005,130000025,130100001}
	-- 레어 등급 카드
	-- 영원의 빛 조각, 거성의 분노, 수도
	local rare={130000037,130000038,130000039}
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
		local reroll=Duel.CreateToken(tp,130000036)
		goods:AddCard(reroll)
	end
	if maxrare == 3 then
		local a = Duel.SelectOption(tp,aux.Stringid(id,3))
	elseif maxrare == 2 then
		local a = Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		local a = Duel.SelectOption(tp,aux.Stringid(id,0))
	end
	 local g=goods:Select(tp,1,1,nil)
	if g:GetFirst():IsCode(130000036) then
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