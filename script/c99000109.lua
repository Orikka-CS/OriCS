--�������� "����"
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,nil,5,4)
	c:EnableReviveLimit()
	--�� ī���� ���ݷ���, �ڽ� ������ "��������" ���� �� "RUM(��ũ �� ����)" ���� ī���� �� �� 300 �ø���.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkup)
	c:RegisterEffect(e1)
	--�� ���͸� ������ ������, �� ���� ���ݷ¸�ŭ�� �������� ��뿡�� �ش�.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--�� ī��� 1���� ��Ʋ ������ �߿� 2ȸ ������ �� �ִ�.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--�� ī�带 ����μ� ������ �ִ� ������ ���ʹ� ������ ȿ���� ��´�.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
s.listed_series={0xc22,0x95}
function s.atkfilter(c)
	return ((c:IsSetCard(0xc22) and c:IsMonster()) or (c:IsSetCard(0x95) and c:IsSpell()))
end
function s.atkup(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	--�� ȿ���� �ߵ��ϴ� �Ͽ�, �� ī��� ������ �� ����.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e:GetHandler():GetAttack()) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if tc:IsLocation(LOCATION_GRAVE) then
			Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
		end
	end
end