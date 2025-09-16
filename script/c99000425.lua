--페넘브라 칸타빌레
local s,id=GetID()
function s.initial_effect(c)
	--이하의 효과에서 1개를 선택하고 발동할 수 있다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={0xc11}
s.listed_names={id}
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)<=2
end
function s.fextrafilter(c)
	return c:IsSetCard(0xc11) and c:IsMonster() and c:IsReleasable()
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_DECK,LOCATION_DECK,1,nil) then
		local eg=Duel.GetMatchingGroup(s.fextrafilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil)
		if #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.extra_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_RELEASE,nil,0,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.extra_operation(e,tc,tp,sg)
	Duel.SendtoGrave(sg,REASON_EFFECT|REASON_RELEASE|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xc11) and (c:IsLocation(LOCATION_DECK) or c:IsFaceup()) and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xc11),
				matfilter=Card.IsReleasable,
				extrafil=s.fextra,
				extratg=s.extra_target,
				extraop=s.extra_operation}
	--"페넘브라 칸타빌레" 이외의 자신의 덱 / 제외 상태인 "페넘브라" 카드 1장을 패에 넣는다.
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil)
	--자신의 패 / 필드의 몬스터를 융합 소재로서 릴리스하고, "페넘브라" 융합 몬스터 1장을 융합 소환한다.
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--"페넘브라 칸타빌레" 이외의 자신의 덱 / 제외 상태인 "페넘브라" 카드 1장을 패에 넣는다.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--자신의 패 / 필드의 몬스터를 융합 소재로서 릴리스하고, "페넘브라" 융합 몬스터 1장을 융합 소환한다.
		local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xc11),
				matfilter=Card.IsReleasable,
				extrafil=s.fextra,
				extraop=s.extra_operation}
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
end