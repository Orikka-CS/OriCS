--에버라스팅 툰드라
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","S")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetCL(1,id)
	WriteEff(e3,3,"NCTO")
	c:RegisterEffect(e3)
end
s.listed_names={15259703}
function s.nfil1(c)
	return c:IsSetCard(0x1062) and c:IsFaceup()
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
		and Duel.IEMCard(s.nfil1,tp,"O","O",1,nil) and rp~=tp
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.nfil3(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IEMCard(s.nfil3,tp,"O",0,1,nil)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.tfil3(c,e,tp)
	return c:IsType(TYPE_TOON) and (c:IsAbleToHand() or
		(Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("G") and s.tfil3(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil3,tp,"G",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil3,tp,"G",0,1,1,nil,e,tp)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SPOI(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then
		return
	end
	aux.ToHandOrElse(tc,tp,
		function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocCount(tp,"M")>0
		end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,0)
	)
end