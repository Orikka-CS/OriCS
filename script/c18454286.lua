--방패의 방어술
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_SUMMON)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"A")
	e4:SetCode(EVENT_CHAINING)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"Qo","G")
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	WriteEff(e5,5,"CTO")
	c:RegisterEffect(e5)
end
function s.nfil1(c)
	return c:IsFaceup() and c:IsSetCard("방패")
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0
		and Duel.IEMCard(s.nfil1,tp,"O",0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SOI(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
		and Duel.IEMCard(s.nfil1,tp,"O",0,1,nil)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.cfil5(c)
	return c:IsSetCard("방패") and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil5,tp,"G",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil5,tp,"G",0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tfil5(c)
	return c:IsSetCard("방패") and c:IsFaceup() and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("R") and s.tfil5(chkc)
	end
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1) and Duel.IETarget(s.tfil5,tp,"R",0,1,nil)
			and (Duel.IETarget(s.tfil5,tp,"R",0,3,nil) or Duel.IEMCard(Card.IsSetCard,tp,"H",0,1,nil,"방패"))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local min=1
	if not Duel.IEMCard(Card.IsSetCard,tp,"H",0,1,nil,"방패") then
		min=3
	end
	local g=Duel.STarget(tp,s.tfil5,tp,"R",0,min,4,nil)
	Duel.SPOI(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsAbleToDeck,nil)
	local min=1
	if #g>=3 then
		min=0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sg=Duel.SMCard(tp,Card.IsSetCard,tp,"H",0,min,1,nil,"방패")
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	elseif #g>=3 then
		Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	else
		return
	end
	Duel.BreakEffect()
	Duel.Draw(tp,1,REASON_EFFECT)
end