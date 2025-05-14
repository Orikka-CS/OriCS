--태풍만한 나비는 나비일까 태풍일까
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTo","M")
	e3:SetCode(id)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"N")
	WriteEff(e3,2,"TO")
	c:RegisterEffect(e3)
	if s.global_check==nil then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(nil,0,"O","O",nil)
	local tc=g:GetFirst()
	local sg=Group.CreateGroup()
	while tc do
		if tc:GetFlagEffect(id+10000000)==0 then
			tc:RegisterFlagEffect(id+10000000,RESET_EVENT+RESETS_STANDARD,0,0)
			if tc:GetPreviousLocation()&LSTN("H")==0 then
				sg:AddCard(tc)
			end
		end
		tc=g:GetNext()
	end
	if #sg>0 then
		Duel.RaiseEvent(sg,id,e,0,0,0,0)
	end
end
function s.tfil1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove() and c:GetTurnID()==Duel.GetTurnCount()
		and c:GetPreviousLocation()&LSTN("H")==0
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsOnField() and s.tfil1(chkc)
	end
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocCount(tp,"M")>0
			and Duel.IETarget(s.tfil1,tp,0,"O",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.STarget(tp,s.tfil1,tp,0,"O",1,1,nil)
	Duel.SOI(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.tfil2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return ckhc:IsControler(1-tp) and chkc:IsLoc("OG") and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,0,"OG",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.STarget(tp,s.tfil2,tp,0,"OG",1,1,nil)
	Duel.SOI(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.nfil3(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsControler(1-tp)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil3,1,nil,tp)
end