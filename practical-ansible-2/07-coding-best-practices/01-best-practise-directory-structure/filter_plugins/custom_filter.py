def improve_automation(a):
    return a.replace("Puppet", "Ansible")


class FilterModule(object):
    """improve_automation filters"""

    @staticmethod
    def filters():
        return {'improve_automation': improve_automation}
