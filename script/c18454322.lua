--볼케이노 사우라
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddBraveProcedure(c,nil,2,6,s.pfun1)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetCL(2,id,EFFECT_COUNT_CODE_DUEL)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","M")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetCL(2,id,EFFECT_COUNT_CODE_DUEL)
	WriteEff(e2,2,"N")
	WriteEff(e2,1,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTo","M")
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCL(1)
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)
end
function s.pfun1(g)
	return g:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id-10000)==0
	end
	Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
end
function s.tfil1(c)
	return c:IsFaceup() and c:GetAttack()>=0
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLoc("M") and s.tfil1(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil1,tp,0,"M",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.STarget(tp,s.tfil1,tp,0,"M",1,1,nil)
	Duel.SOI(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.Equip(tp,tc,c) then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.oval11)
			tc:RegisterEffect(e1)
			if tc:GetTextAttack()>0 then
				local e2=MakeEff(c,"E")
				e2:SetCode(EFFECT_UPDATE_BRAVE)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(tc:GetTextAttack())
				tc:RegisterEffect(e2)
			end
		end
	end
end
function s.oval11(e,c)
	return e:GetOwner()==c
end
function s.nfil2(c,tp)
	return c:IsFaceup()and c:IsSummonPlayer(1-tp) and c:GetAttack()>=0 
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil2,1,nil,tp)
end
function s.cfil3(c)
	return c:GetTextAttack()>0 and c:GetFlagEffect(id)~=0
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.cfil3,nil)
	if chk==0 then
		return #g>0
	end
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	local tatk=tc:GetTextAttack()
	local ttype=tc:GetType()
	e:SetLabel(tatk)
	tc:Type(ttype|TYPE_TOKEN)
	Duel.SendtoGrave(tc,REASON_COST)
	table.insert(Auxiliary.BurningZone[tc:GetOwner()],tc)
	Auxiliary.BurningZoneTopCardOperation(e,tp,eg,ep,ev,re,r,rp)
	tc:Type(ttype)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,e:GetLabel(),REASON_EFFECT)
end