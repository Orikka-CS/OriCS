--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	aux.AddDelightProcedure(c,aux.FBF(Card.IsSetCard,0x5d72),3,3)

	local e1=MakeEff(c,"S","M")
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	
	local e2=MakeEff(c,"STo")
	e2:SetCategory(CATEGORY_SET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCL(1,id)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"FC","R")
	e3:SetCode(EVENT_ADJUST)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	WriteEff(e3,3,"NO")
	c:RegisterEffect(e3)
	
	aux.GlobalCheck(s,function()
		s[0]=0
		aux.AddValuesReset(function()
			s[0]=0
		end)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e4:SetCode(EVENT_CHAINING)
		e4:SetOperation(s.checkop)
		Duel.RegisterEffect(e4,0)
	end)
	
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local temp=re:GetActiveType()&0x7
	local p=e:GetHandlerPlayer()
	if rp~=p and s[0]==temp then
		Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_END,0,1)
	end
	s[0]=temp
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end

function s.cost2f(c)
	return c:IsST() and c:IsSetCard(0x5d72) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.cost2f,tp,LOCATION_DECK,0,nil)
		e:SetLabelObject(g)
		return #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=e:GetLabelObject():Select(tp,1,1,nil):GetFirst()
	e:SetLabelObject(sc)
	Duel.SendtoGrave(sc,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
		return te and te:GetTarget() and te:GetTarget()(e,tp,ceg,cep,cev,cre,cr,crp,chk,chkc)
	end
	if chk==0 then
		local res=e:GetLabel()==-100
		e:SetLabel(0)
		return res
	end
	local sc=e:GetLabelObject()
	local te,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		e:SetProperty(te:GetProperty())
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(0)
	e:SetLabelObject({te,ceg,cep,cev,cre,cr,crp})
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
	if not te then return end
	local op=te:GetOperation()
	if op then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		op(e,tp,ceg,cep,cev,cre,cr,crp)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end

function s.con3(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummon(tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsFacedown()
		and (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.HasFlagEffect(tp,id,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.ResetFlagEffect(tp,id)
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,s[0]),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			Duel.HintSelection(dg,true)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end


