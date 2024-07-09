--¸£ºí¶û ½ºÆ®¸²
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetD(id,0)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","H")
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTR(POS_FACEUP,1)
	e2:SetD(id,1)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S","M")
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.con3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STf")
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetCL(1,id)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
end
function s.nfil1(c)
	return c:IsSetCard("¸£ºí¶û") and c:IsFaceup()
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.nfil1,tp,"M","M",1,nil)
end
function s.con2(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(1-tp,"M")>0 and Duel.IEMCard(s.nfil1,tp,"M","M",1,nil)
end
function s.con3(e)
	return Duel.IsBattlePhase()
end
function s.val3(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	local op=c:GetOwner()
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,op,"D")
end
function s.ofil4(c,tp)
	return c:IsSetCard("¸£ºí¶û") and c:IsType(TYPE_CONTINUOUS)
		and (c:IsAbleToHand() or (Duel.GetLocCount(1-tp,"S")>0 and not c:IsForidden()))
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=c:GetOwner()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(op,s.ofil4,op,"D",0,1,1,nil,op)
	local tc=g:GetFirst()
	if not tc then
		return
	end
	aux.ToHandOrElse(tc,op,
		function(sc)
			return Duel.GetLocCount(1-op,"S")>0 and not sc:IsForbidden()
		end,
		function(sc)
			Duel.MoveToField(sc,op,1-op,LSTN("S"),POS_FACEUP,true)
		end,
		aux.Stringid(id,2)
	)
end