--테스트기어 가이아스 라비아스
local s,id=GetID()
function c640.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	local e2=aux.AddLavaProcedure(c,0,POS_FACEUP,aux.TRUE,0,aux.Stringid(id,1))
	e2:SetCondition(s.hspcon2)
	e2:SetCountLimit(1,id)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+35)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0x256a}
s.listed_names={id}
s.material_setcode=0x256a
function s.ssacechk(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x256a),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.hspcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),aux.TRUE,1,false,1,true,c,c:GetControler(),nil,false,nil) and s.ssacechk(e)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.hspcon2(e,c)
	if c==nil then return true end
	return aux.LavaCondition(1,nil)(e,c) and s.ssacechk(e)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,e:GetHandler():GetOwner(),LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(0x256a) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(p,s.thfilter,p,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,p,REASON_EFFECT)
		Duel.ConfirmCards(1-p,g)
	end
end