--[ S¢Óigma ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_DESTROY)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	e2:SetDescription(aux.Stringid(id,2))
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.SelfBanishCost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
	
end

function s.tfil1(c,e,tp)
	return c:IsSetCard(0x6d70) and c:IsAttribute(ATT_L) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)>0 then
	
		local b1=Duel.IsPlayerCanDraw(tp,2) 
		local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		if not ((b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,3))) then return end
		
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)})

		if op==1 then
			Duel.BreakEffect()
			Duel.Draw(tp,2,REASON_EFFECT)
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
			if #sg>0 then
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end

function s.confil(c)
	return c:IsAttribute(ATT_D) and c:IsFaceup() and c:IsSetCard(0x6d70)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.confil,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.matfil(c,tp)
	return c:IsSetCard(0x6d70) and c:IsFaceup() and Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,c)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfil,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectMatchingCard(tp,s.matfil,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g==0 then return end
	Duel.HintSelection(g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyzc=Duel.SelectMatchingCard(tp,Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,1,nil,g):GetFirst()
	if xyzc then
		Duel.XyzSummon(tp,xyzc,g)
	end
end
